// // use crate::users_mongo::model::UserRedis;
// use bb8::Pool;
// use bb8_redis::RedisConnectionManager;
// use redis::{AsyncCommands, RedisError};
// use serde::de::DeserializeOwned;
// use serde::Serialize;
// use serde_json::from_str;
//
// pub async fn get_users_redis<T: DeserializeOwned + Serialize>(
//     pool: &Pool<RedisConnectionManager>,
//     key: &str,
// ) -> Result<Option<Vec<T>>, RedisError> {
//     // Acquire a connection from the pool
//     let mut conn = pool.get().await.map_err(|e| {
//         RedisError::from((
//             redis::ErrorKind::IoError,
//             "Failed to get connection from pool",
//             e.to_string(),
//         ))
//     })?;
//
//     // Attempt to fetch the serialized string from Redis using the `get` command from the `AsyncCommands` trait
//     let serialized_users: Option<String> = conn.get(key).await.map_err(|e| {
//         RedisError::from((
//             redis::ErrorKind::IoError,
//             "Failed to execute get command",
//             e.to_string(),
//         ))
//     })?;
//
//     match serialized_users {
//         Some(data) => {
//             from_str::<Vec<T>>(data.as_str()).map(Some).map_err(|_e| {
//                 RedisError::from((redis::ErrorKind::TypeError, "Failed to deserialize data"))
//             })
//             // Attempt to deserialize the string back into Vec<UserRedis>
//             // from_str(&s)
//             //     .map(Some) // Wrap the result in Some if successful
//             //     .map_err(|_e| {
//             //         RedisError::from((redis::ErrorKind::TypeError, "Failed to deserialize data"))
//             //     })
//         }
//         None => Ok(None), // Key does not exist
//     }
// }
