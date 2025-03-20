use axum::{
  http::StatusCode,
  response::{Html, IntoResponse},
  routing::get,
  Router,
};
use lib_utils::tracing::init_tracing;

#[tokio::main]
async fn main() {
  init_tracing();
  tracing::info!("Initializing application");
  // build our application with a route
  let app = Router::new().route("/", get(handler))
    .route("/health", get(handler));

  // add a fallback service for handling routes to unknown paths
  let app = app.fallback(handler_404);

  // run it
  let listener = tokio::net::TcpListener::bind("0.0.0.0:8080")
    .await
    .unwrap();
  tracing::debug!("listening on {}", listener.local_addr().unwrap());
  axum::serve(listener, app).await.unwrap();
}

async fn handler() -> Html<&'static str> {
  Html("<h1>Hello, World!</h1>")
}

async fn handler_404() -> impl IntoResponse {
  (StatusCode::NOT_FOUND, "nothing to see here")
}
