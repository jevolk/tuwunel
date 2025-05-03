use ruma::events::relation::RelationType;
use serde::Deserialize;

use super::Event;

pub trait RelationTypeEqual<E: Event> {
	fn relation_type_equal(&self, event: &E) -> bool;
}

#[derive(Clone, Debug, Deserialize)]
struct ExtractRelatesToEventId {
	#[serde(rename = "m.relates_to")]
	relates_to: ExtractRelType,
}

#[derive(Clone, Debug, Deserialize)]
struct ExtractRelType {
	rel_type: RelationType,
}

impl<E: Event> RelationTypeEqual<E> for RelationType {
	fn relation_type_equal(&self, event: &E) -> bool {
		event
			.get_content()
			.map(|c: ExtractRelatesToEventId| c.relates_to.rel_type)
			.is_ok_and(|r| r == *self)
	}
}
