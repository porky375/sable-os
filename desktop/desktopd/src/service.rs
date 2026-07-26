use crate::state::{DesktopState, StateStore};
use std::sync::Arc;
use tokio::sync::RwLock;
use zbus::{interface, object_server::SignalEmitter};

pub struct DesktopService {
    state: Arc<RwLock<DesktopState>>,
    store: Arc<StateStore>,
}

impl DesktopService {
    pub fn new(state: DesktopState, store: StateStore) -> Self {
        Self {
            state: Arc::new(RwLock::new(state)),
            store: Arc::new(store),
        }
    }

    async fn save_and_emit(&self, signal_emitter: &SignalEmitter<'_>) -> zbus::fdo::Result<()> {
        let state = self.state.read().await.clone();
        self.store
            .save(&state)
            .map_err(|error| zbus::fdo::Error::Failed(error.to_string()))?;
        let json = serde_json::to_string(&state)
            .map_err(|error| zbus::fdo::Error::Failed(error.to_string()))?;
        Self::state_changed(signal_emitter, &json)
            .await
            .map_err(|error| zbus::fdo::Error::Failed(error.to_string()))
    }
}

#[interface(name = "org.sable.Desktop1")]
impl DesktopService {
    async fn list_workspaces(&self) -> zbus::fdo::Result<String> {
        serde_json::to_string(&*self.state.read().await)
            .map_err(|error| zbus::fdo::Error::Failed(error.to_string()))
    }

    async fn create_workspace(
        &self,
        name: &str,
        #[zbus(signal_emitter)] signal_emitter: SignalEmitter<'_>,
    ) -> zbus::fdo::Result<String> {
        let id = self
            .state
            .write()
            .await
            .create_workspace(name)
            .map_err(|error| zbus::fdo::Error::InvalidArgs(error.to_string()))?;
        self.save_and_emit(&signal_emitter).await?;
        Ok(id)
    }

    async fn rename_workspace(
        &self,
        id: &str,
        name: &str,
        #[zbus(signal_emitter)] signal_emitter: SignalEmitter<'_>,
    ) -> zbus::fdo::Result<bool> {
        let changed = self
            .state
            .write()
            .await
            .rename_workspace(id, name)
            .map_err(|error| zbus::fdo::Error::InvalidArgs(error.to_string()))?;
        if changed {
            self.save_and_emit(&signal_emitter).await?;
        }
        Ok(changed)
    }

    async fn delete_workspace(
        &self,
        id: &str,
        #[zbus(signal_emitter)] signal_emitter: SignalEmitter<'_>,
    ) -> zbus::fdo::Result<bool> {
        let changed = self
            .state
            .write()
            .await
            .delete_workspace(id)
            .map_err(|error| zbus::fdo::Error::InvalidArgs(error.to_string()))?;
        if changed {
            self.save_and_emit(&signal_emitter).await?;
        }
        Ok(changed)
    }

    async fn reorder_workspace(
        &self,
        id: &str,
        target_index: u32,
        #[zbus(signal_emitter)] signal_emitter: SignalEmitter<'_>,
    ) -> zbus::fdo::Result<bool> {
        let changed = self.state.write().await.reorder_workspace(id, target_index);
        if changed {
            self.save_and_emit(&signal_emitter).await?;
        }
        Ok(changed)
    }

    async fn set_active_workspace(
        &self,
        id: &str,
        #[zbus(signal_emitter)] signal_emitter: SignalEmitter<'_>,
    ) -> zbus::fdo::Result<bool> {
        let changed = self.state.write().await.set_active_workspace(id);
        if changed {
            self.save_and_emit(&signal_emitter).await?;
        }
        Ok(changed)
    }

    async fn apply_profile(
        &self,
        profile_json: &str,
        #[zbus(signal_emitter)] signal_emitter: SignalEmitter<'_>,
    ) -> zbus::fdo::Result<()> {
        let state: DesktopState = serde_json::from_str(profile_json)
            .map_err(|error| zbus::fdo::Error::InvalidArgs(error.to_string()))?;
        state
            .validate()
            .map_err(|error| zbus::fdo::Error::InvalidArgs(error.to_string()))?;
        *self.state.write().await = state;
        self.save_and_emit(&signal_emitter).await
    }

    #[zbus(property)]
    async fn active_workspace_id(&self) -> String {
        self.state.read().await.active_workspace_id.clone()
    }

    #[zbus(signal)]
    async fn state_changed(
        signal_emitter: &SignalEmitter<'_>,
        state_json: &str,
    ) -> zbus::Result<()>;

    #[zbus(signal)]
    async fn window_opened(
        signal_emitter: &SignalEmitter<'_>,
        window_json: &str,
    ) -> zbus::Result<()>;

    #[zbus(signal)]
    async fn window_closed(signal_emitter: &SignalEmitter<'_>, address: &str) -> zbus::Result<()>;

    #[zbus(signal)]
    async fn minimized_windows_changed(
        signal_emitter: &SignalEmitter<'_>,
        windows_json: &str,
    ) -> zbus::Result<()>;

    #[zbus(signal)]
    async fn monitors_changed(
        signal_emitter: &SignalEmitter<'_>,
        monitors_json: &str,
    ) -> zbus::Result<()>;

    #[zbus(signal)]
    async fn game_mode_changed(
        signal_emitter: &SignalEmitter<'_>,
        active: bool,
    ) -> zbus::Result<()>;
}
