use sn_node::{Config, Node};
use std::{
    thread::JoinHandle,
    time::Duration,
};
use std::{
    error::Error,
    net::{IpAddr, SocketAddr},
};
use tokio::runtime::{Runtime};

use std::path::PathBuf;
use structopt::StructOpt;

#[derive(StructOpt, Debug)]
#[structopt()]
struct Opt {
    #[structopt(short, long)]
    local: IpAddr,

    #[structopt(short, long)]
    external: Option<IpAddr>,

    #[structopt(short, long, default_value = "12000")]
    port: u16,

    #[structopt(short, long, default_value = ".safe/node", parse(from_os_str))]
    dir: PathBuf,

    #[structopt(short, long, default_value = "12")]
    size: u16,
}

async fn run(config: Config) -> sn_node::Result<()> {
    let mut node = Node::new(&config).await?;
    node.run().await?;

    Ok(())
}

fn main() -> Result<(), Box<dyn Error>> {
    let opt: Opt = Opt::from_args();

    let mut config = Config::default();
    config.network_config.local_ip = Some(opt.local);
    config.network_config.external_ip = opt.external;

    env_logger::init();

    let mut t = vec![];

    for i in 0..opt.size {
        let mut config = config.clone();
        let port = opt.port + i;

        if i == 0 {
            config.first = true;
        } else {
            config
                .network_config
                .hard_coded_contacts
                .insert(SocketAddr::new("127.0.0.1".parse()?, opt.port));
        }

        config.root_dir = Some(opt.dir.join(port.to_string()));
        config.network_config.local_port = Some(port);
        if opt.external.is_some() {
            config.network_config.external_port = Some(port);
        }

        let handle: JoinHandle<sn_node::Result<()>> = std::thread::Builder::new()
            .stack_size(8 * 1024 * 1024)
            .spawn(move || {
                let mut runtime = Runtime::new().unwrap();
                runtime.block_on(run(config))
            })?;
        t.push(handle);

        std::thread::sleep(Duration::from_secs(1));
    }

    for handle in t {
        handle.join().unwrap()?;
    }

    Ok(())
}
