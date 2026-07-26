use anyhow::{Context, Result, bail};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::{Path, PathBuf};
use uuid::Uuid;

pub const STATE_SCHEMA_VERSION: u32 = 1;

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Workspace {
    pub id: String,
    pub name: String,
}

#[derive(Clone, Debug, Deserialize, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct DesktopState {
    pub schema_version: u32,
    pub active_workspace_id: String,
    pub workspaces: Vec<Workspace>,
}

impl Default for DesktopState {
    fn default() -> Self {
        let workspace = Workspace {
            id: Uuid::new_v4().to_string(),
            name: "Desktop 1".to_owned(),
        };
        Self {
            schema_version: STATE_SCHEMA_VERSION,
            active_workspace_id: workspace.id.clone(),
            workspaces: vec![workspace],
        }
    }
}

impl DesktopState {
    pub fn validate(&self) -> Result<()> {
        if self.schema_version != STATE_SCHEMA_VERSION {
            bail!(
                "unsupported desktop state schema {}, expected {}",
                self.schema_version,
                STATE_SCHEMA_VERSION
            );
        }
        if self.workspaces.is_empty() {
            bail!("at least one workspace is required");
        }
        if !self
            .workspaces
            .iter()
            .any(|workspace| workspace.id == self.active_workspace_id)
        {
            bail!("active workspace does not exist");
        }

        for workspace in &self.workspaces {
            validate_name(&workspace.name)?;
        }

        for (index, workspace) in self.workspaces.iter().enumerate() {
            if self.workspaces[index + 1..]
                .iter()
                .any(|candidate| candidate.id == workspace.id)
            {
                bail!("duplicate workspace id {}", workspace.id);
            }
        }
        Ok(())
    }

    pub fn create_workspace(&mut self, name: &str) -> Result<String> {
        validate_name(name)?;
        let id = Uuid::new_v4().to_string();
        self.workspaces.push(Workspace {
            id: id.clone(),
            name: name.trim().to_owned(),
        });
        Ok(id)
    }

    pub fn rename_workspace(&mut self, id: &str, name: &str) -> Result<bool> {
        validate_name(name)?;
        let Some(workspace) = self
            .workspaces
            .iter_mut()
            .find(|workspace| workspace.id == id)
        else {
            return Ok(false);
        };
        workspace.name = name.trim().to_owned();
        Ok(true)
    }

    pub fn delete_workspace(&mut self, id: &str) -> Result<bool> {
        if self.workspaces.len() == 1 {
            bail!("the final workspace cannot be deleted");
        }
        let Some(index) = self
            .workspaces
            .iter()
            .position(|workspace| workspace.id == id)
        else {
            return Ok(false);
        };

        self.workspaces.remove(index);
        if self.active_workspace_id == id {
            let fallback = index.saturating_sub(1).min(self.workspaces.len() - 1);
            self.active_workspace_id = self.workspaces[fallback].id.clone();
        }
        Ok(true)
    }

    pub fn reorder_workspace(&mut self, id: &str, target_index: u32) -> bool {
        let Some(source_index) = self
            .workspaces
            .iter()
            .position(|workspace| workspace.id == id)
        else {
            return false;
        };

        let workspace = self.workspaces.remove(source_index);
        let target_index = (target_index as usize).min(self.workspaces.len());
        self.workspaces.insert(target_index, workspace);
        true
    }

    pub fn set_active_workspace(&mut self, id: &str) -> bool {
        if self.workspaces.iter().any(|workspace| workspace.id == id) {
            self.active_workspace_id = id.to_owned();
            true
        } else {
            false
        }
    }
}

fn validate_name(name: &str) -> Result<()> {
    let name = name.trim();
    if name.is_empty() {
        bail!("workspace name cannot be empty");
    }
    if name.chars().count() > 48 {
        bail!("workspace name cannot exceed 48 characters");
    }
    if name.chars().any(char::is_control) {
        bail!("workspace name cannot contain control characters");
    }
    Ok(())
}

#[derive(Debug)]
pub struct StateStore {
    path: PathBuf,
}

impl StateStore {
    pub fn new(path: PathBuf) -> Self {
        Self { path }
    }

    pub fn default_path() -> Result<PathBuf> {
        if let Some(state_home) = std::env::var_os("XDG_STATE_HOME") {
            return Ok(PathBuf::from(state_home).join("sable/desktop.json"));
        }

        let home = std::env::var_os("HOME").context("HOME is not set")?;
        Ok(PathBuf::from(home).join(".local/state/sable/desktop.json"))
    }

    pub fn load(&self) -> Result<DesktopState> {
        if !self.path.exists() {
            let state = DesktopState::default();
            self.save(&state)?;
            return Ok(state);
        }

        let contents = fs::read_to_string(&self.path)
            .with_context(|| format!("failed to read {}", self.path.display()))?;
        let state: DesktopState = serde_json::from_str(&contents)
            .with_context(|| format!("failed to parse {}", self.path.display()))?;
        state.validate()?;
        Ok(state)
    }

    pub fn save(&self, state: &DesktopState) -> Result<()> {
        state.validate()?;
        let parent = self
            .path
            .parent()
            .context("state path does not have a parent directory")?;
        fs::create_dir_all(parent)
            .with_context(|| format!("failed to create {}", parent.display()))?;

        let temporary = temporary_path(&self.path);
        let payload = serde_json::to_vec_pretty(state)?;
        fs::write(&temporary, payload)
            .with_context(|| format!("failed to write {}", temporary.display()))?;
        fs::rename(&temporary, &self.path).with_context(|| {
            format!(
                "failed to atomically replace {} with {}",
                self.path.display(),
                temporary.display()
            )
        })?;
        Ok(())
    }
}

fn temporary_path(path: &Path) -> PathBuf {
    let mut temporary = path.as_os_str().to_owned();
    temporary.push(format!(".{}.tmp", std::process::id()));
    PathBuf::from(temporary)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cannot_delete_last_workspace() {
        let mut state = DesktopState::default();
        let id = state.active_workspace_id.clone();
        assert!(state.delete_workspace(&id).is_err());
    }

    #[test]
    fn deleting_active_workspace_selects_a_fallback() {
        let mut state = DesktopState::default();
        let first = state.active_workspace_id.clone();
        let second = state.create_workspace("Games").unwrap();
        assert!(state.set_active_workspace(&second));
        assert!(state.delete_workspace(&second).unwrap());
        assert_eq!(state.active_workspace_id, first);
    }

    #[test]
    fn state_round_trips_atomically() {
        let directory = tempfile::tempdir().unwrap();
        let store = StateStore::new(directory.path().join("desktop.json"));
        let mut state = DesktopState::default();
        state.create_workspace("Work").unwrap();
        store.save(&state).unwrap();
        assert_eq!(store.load().unwrap(), state);
    }

    #[test]
    fn reordering_preserves_identity() {
        let mut state = DesktopState::default();
        let first = state.active_workspace_id.clone();
        let second = state.create_workspace("Work").unwrap();
        assert!(state.reorder_workspace(&second, 0));
        assert_eq!(state.workspaces[0].id, second);
        assert_eq!(state.workspaces[1].id, first);
    }
}
