#[ic_cdk::query]
fn hobby(name: String) -> String {
    format!("My hobby is, {}!", name)
}
