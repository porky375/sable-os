mod service;
mod state;

use anyhow::{Context, Result};
use service::DesktopService;
use state::StateStore;
use zbus::connection;

const BUS_NAME: &str = "org.sable.Desktop1";
const OBJECT_PATH: &str = "/org/sable/Desktop1";

#[tokio::main]
async fn main() -> Result<()> {
    let arguments: Vec<String> = std::env::args().collect();
    let store = StateStore::new(StateStore::default_path()?);

    if arguments.iter().any(|argument| argument == "--print-state") {
        println!("{}", serde_json::to_string_pretty(&store.load()?)?);
        return Ok(());
    }

    let state = store.load()?;
    let service = DesktopService::new(state, store);
    let _connection = connection::Builder::session()?
        .name(BUS_NAME)?
        .serve_at(OBJECT_PATH, service)?
        .build()
        .await
        .context("failed to register desktop D-Bus service")?;

    tokio::signal::ctrl_c()
        .await
        .context("failed to wait for shutdown signal")?;
    Ok(())
}
