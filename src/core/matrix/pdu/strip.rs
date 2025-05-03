use ruma::{
	events::{
		AnyMessageLikeEvent, AnyStateEvent, AnyStrippedStateEvent, AnySyncStateEvent,
		AnySyncTimelineEvent, AnyTimelineEvent, StateEvent, room::member::RoomMemberEventContent,
		space::child::HierarchySpaceChildEvent,
	},
	serde::Raw,
};
use serde_json::{json, value::Value as JsonValue};

use crate::implement;

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn into_room_event(self) -> Raw<AnyTimelineEvent> { self.to_room_event() }

#[implement(super::Pdu)]
#[must_use]
pub fn to_room_event(&self) -> Raw<AnyTimelineEvent> {
	let value = self.to_room_event_value();
	serde_json::from_value(value).expect("Failed to serialize Event value")
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn to_room_event_value(&self) -> JsonValue {
	let (redacts, content) = self.copy_redacts();
	let mut json = json!({
		"content": content,
		"type": self.kind,
		"event_id": self.event_id,
		"sender": self.sender,
		"origin_server_ts": self.origin_server_ts,
		"room_id": self.room_id,
	});

	if let Some(unsigned) = &self.unsigned {
		json["unsigned"] = json!(unsigned);
	}
	if let Some(state_key) = &self.state_key {
		json["state_key"] = json!(state_key);
	}
	if let Some(redacts) = &redacts {
		json["redacts"] = json!(redacts);
	}

	json
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn into_message_like_event(self) -> Raw<AnyMessageLikeEvent> { self.to_message_like_event() }

#[implement(super::Pdu)]
#[must_use]
pub fn to_message_like_event(&self) -> Raw<AnyMessageLikeEvent> {
	let value = self.to_message_like_event_value();
	serde_json::from_value(value).expect("Failed to serialize Event value")
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn to_message_like_event_value(&self) -> JsonValue {
	let (redacts, content) = self.copy_redacts();
	let mut json = json!({
		"content": content,
		"type": self.kind,
		"event_id": self.event_id,
		"sender": self.sender,
		"origin_server_ts": self.origin_server_ts,
		"room_id": self.room_id,
	});

	if let Some(unsigned) = &self.unsigned {
		json["unsigned"] = json!(unsigned);
	}
	if let Some(state_key) = &self.state_key {
		json["state_key"] = json!(state_key);
	}
	if let Some(redacts) = &redacts {
		json["redacts"] = json!(redacts);
	}

	json
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn into_sync_room_event(self) -> Raw<AnySyncTimelineEvent> { self.to_sync_room_event() }

#[implement(super::Pdu)]
#[must_use]
pub fn to_sync_room_event(&self) -> Raw<AnySyncTimelineEvent> {
	let value = self.to_sync_room_event_value();
	serde_json::from_value(value).expect("Failed to serialize Event value")
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn to_sync_room_event_value(&self) -> JsonValue {
	let (redacts, content) = self.copy_redacts();
	let mut json = json!({
		"content": content,
		"type": self.kind,
		"event_id": self.event_id,
		"sender": self.sender,
		"origin_server_ts": self.origin_server_ts,
	});

	if let Some(unsigned) = &self.unsigned {
		json["unsigned"] = json!(unsigned);
	}
	if let Some(state_key) = &self.state_key {
		json["state_key"] = json!(state_key);
	}
	if let Some(redacts) = &redacts {
		json["redacts"] = json!(redacts);
	}

	json
}

#[implement(super::Pdu)]
#[must_use]
pub fn into_state_event(self) -> Raw<AnyStateEvent> {
	let value = self.into_state_event_value();
	serde_json::from_value(value).expect("Failed to serialize Event value")
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn into_state_event_value(self) -> JsonValue {
	let mut json = json!({
		"content": self.content,
		"type": self.kind,
		"event_id": self.event_id,
		"sender": self.sender,
		"origin_server_ts": self.origin_server_ts,
		"room_id": self.room_id,
		"state_key": self.state_key,
	});

	if let Some(unsigned) = self.unsigned {
		json["unsigned"] = json!(unsigned);
	}

	json
}

#[implement(super::Pdu)]
#[must_use]
pub fn into_sync_state_event(self) -> Raw<AnySyncStateEvent> {
	let value = self.into_sync_state_event_value();
	serde_json::from_value(value).expect("Failed to serialize Event value")
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn into_sync_state_event_value(self) -> JsonValue {
	let mut json = json!({
		"content": self.content,
		"type": self.kind,
		"event_id": self.event_id,
		"sender": self.sender,
		"origin_server_ts": self.origin_server_ts,
		"state_key": self.state_key,
	});

	if let Some(unsigned) = &self.unsigned {
		json["unsigned"] = json!(unsigned);
	}

	json
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn into_stripped_state_event(self) -> Raw<AnyStrippedStateEvent> {
	self.to_stripped_state_event()
}

#[implement(super::Pdu)]
#[must_use]
pub fn to_stripped_state_event(&self) -> Raw<AnyStrippedStateEvent> {
	let value = self.to_stripped_state_event_value();
	serde_json::from_value(value).expect("Failed to serialize Event value")
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn to_stripped_state_event_value(&self) -> JsonValue {
	json!({
		"content": self.content,
		"type": self.kind,
		"sender": self.sender,
		"state_key": self.state_key,
	})
}

#[implement(super::Pdu)]
#[must_use]
pub fn into_stripped_spacechild_state_event(self) -> Raw<HierarchySpaceChildEvent> {
	let value = self.into_stripped_spacechild_state_event_value();
	serde_json::from_value(value).expect("Failed to serialize Event value")
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn into_stripped_spacechild_state_event_value(self) -> JsonValue {
	json!({
		"content": self.content,
		"type": self.kind,
		"sender": self.sender,
		"state_key": self.state_key,
		"origin_server_ts": self.origin_server_ts,
	})
}

#[implement(super::Pdu)]
#[must_use]
pub fn into_member_event(self) -> Raw<StateEvent<RoomMemberEventContent>> {
	let value = self.into_member_event_value();
	serde_json::from_value(value).expect("Failed to serialize Event value")
}

#[implement(super::Pdu)]
#[must_use]
#[inline]
pub fn into_member_event_value(self) -> JsonValue {
	let mut json = json!({
		"content": self.content,
		"type": self.kind,
		"event_id": self.event_id,
		"sender": self.sender,
		"origin_server_ts": self.origin_server_ts,
		"redacts": self.redacts,
		"room_id": self.room_id,
		"state_key": self.state_key,
	});

	if let Some(unsigned) = self.unsigned {
		json["unsigned"] = json!(unsigned);
	}

	json
}
