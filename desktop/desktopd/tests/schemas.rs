use jsonschema::validator_for;
use serde_json::Value;
use std::fs;
use std::path::{Path, PathBuf};

fn project_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../..")
        .canonicalize()
        .unwrap()
}

fn load(relative_path: &str) -> Value {
    let path = project_root().join(relative_path);
    serde_json::from_str(&fs::read_to_string(&path).unwrap()).unwrap()
}

#[test]
fn default_pack_matches_schema() {
    let schema = load("schemas/desktop-pack.schema.json");
    let instance = load("examples/packs/monochrome-default.json");
    let validator = validator_for(&schema).unwrap();
    assert!(validator.is_valid(&instance));
}

#[test]
fn example_snapshot_matches_schema() {
    let schema = load("schemas/snapshot.schema.json");
    let instance = load("examples/snapshots/testing.json");
    let validator = validator_for(&schema).unwrap();
    assert!(validator.is_valid(&instance));
}
