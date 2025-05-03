use std::collections::BTreeMap;

use axum::extract::State;
use ruma::{
	api::client::tag::{create_tag, delete_tag, get_tags},
	events::{
		RoomAccountDataEventType,
		tag::{TagEvent, TagEventContent},
	},
};
use tuwunel_core::Result;

use crate::Ruma;

/// # `PUT /_matrix/client/r0/user/{userId}/rooms/{roomId}/tags/{tag}`
///
/// Adds a tag to the room.
///
/// - Inserts the tag into the tag event of the room account data.
pub(crate) async fn update_tag_route(
	State(services): State<crate::State>,
	body: Ruma<create_tag::v3::Request>,
) -> Result<create_tag::v3::Response> {
	let sender_user = body.sender_user();

	let mut tags_event = services
		.account_data
		.get_room(&body.room_id, sender_user, RoomAccountDataEventType::Tag)
		.await
		.unwrap_or(TagEvent {
			content: TagEventContent { tags: BTreeMap::new() },
		});

	tags_event
		.content
		.tags
		.insert(body.tag.clone().into(), body.tag_info.clone());

	services
		.account_data
		.update(
			Some(&body.room_id),
			sender_user,
			RoomAccountDataEventType::Tag,
			&serde_json::to_value(tags_event)?,
		)
		.await?;

	Ok(create_tag::v3::Response {})
}

/// # `DELETE /_matrix/client/r0/user/{userId}/rooms/{roomId}/tags/{tag}`
///
/// Deletes a tag from the room.
///
/// - Removes the tag from the tag event of the room account data.
pub(crate) async fn delete_tag_route(
	State(services): State<crate::State>,
	body: Ruma<delete_tag::v3::Request>,
) -> Result<delete_tag::v3::Response> {
	let sender_user = body.sender_user();

	let mut tags_event = services
		.account_data
		.get_room(&body.room_id, sender_user, RoomAccountDataEventType::Tag)
		.await
		.unwrap_or(TagEvent {
			content: TagEventContent { tags: BTreeMap::new() },
		});

	tags_event
		.content
		.tags
		.remove(&body.tag.clone().into());

	services
		.account_data
		.update(
			Some(&body.room_id),
			sender_user,
			RoomAccountDataEventType::Tag,
			&serde_json::to_value(tags_event)?,
		)
		.await?;

	Ok(delete_tag::v3::Response {})
}

/// # `GET /_matrix/client/r0/user/{userId}/rooms/{roomId}/tags`
///
/// Returns tags on the room.
///
/// - Gets the tag event of the room account data.
pub(crate) async fn get_tags_route(
	State(services): State<crate::State>,
	body: Ruma<get_tags::v3::Request>,
) -> Result<get_tags::v3::Response> {
	let sender_user = body.sender_user();

	let tags_event = services
		.account_data
		.get_room(&body.room_id, sender_user, RoomAccountDataEventType::Tag)
		.await
		.unwrap_or(TagEvent {
			content: TagEventContent { tags: BTreeMap::new() },
		});

	Ok(get_tags::v3::Response { tags: tags_event.content.tags })
}
