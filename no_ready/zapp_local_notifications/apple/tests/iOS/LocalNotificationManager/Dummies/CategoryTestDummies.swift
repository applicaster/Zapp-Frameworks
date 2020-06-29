//
//  TriggerTestDummies.swift
//  ZappLocalNotifications
//
//  Created by Anton Kononenko on 3/18/20.
//

import Foundation
import ZappCore
//
// actions:[{
//       identifier: String,
//       title: String,
//       url: String,
//       buttonType: String [default|danger]
//   }

let category_data_empty: [AnyHashable: Any] = [:]

let category_data: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions:
    [
        [
            LocalNotificationPayloadActions.title: "Title",
            LocalNotificationPayloadActions.identifier: "id_1",
            LocalNotificationPayloadActions.buttonType: "default",
        ],
        [
            LocalNotificationPayloadActions.title: "Title",
            LocalNotificationPayloadActions.identifier: "id_2",
            LocalNotificationPayloadActions.buttonType: "danger",
        ],
]]

let category_data_corrupted: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions:
    [
        [
            LocalNotificationPayloadActions.title: "Title",
            LocalNotificationPayloadActions.identifier: "id_1",
            LocalNotificationPayloadActions.buttonType: "default",
        ],
        [
            LocalNotificationPayloadActions.title: "Title",
            LocalNotificationPayloadActions.buttonType: "danger",
        ],
]]

let category_data_wrong_structure: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions:
    [["wrong_structure"]],
]

let actions_button_from_payload_data_empty: [AnyHashable: Any] = [:]
let actions_button_from_payload_data: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions:
    [
        [
            LocalNotificationPayloadActions.title: "Title",
            LocalNotificationPayloadActions.identifier: "id_1",
            LocalNotificationPayloadActions.buttonType: "default",
        ],
]]
let actions_button_from_payload_data_corrupted: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions:
    [["wrong_structure"]],
]

let actions_button_for_category_empty: [[AnyHashable: Any]] = []

let actions_button_for_category: [[AnyHashable: Any]] = [
    [
        LocalNotificationPayloadActions.title: "Title",
        LocalNotificationPayloadActions.identifier: "id_1",
        LocalNotificationPayloadActions.buttonType: "default",
    ],
    [
        LocalNotificationPayloadActions.title: "Title",
        LocalNotificationPayloadActions.identifier: "id_2",
        LocalNotificationPayloadActions.buttonType: "danger",
    ],
]

let actions_button_for_category_same_id: [[AnyHashable: Any]] = [
    [
        LocalNotificationPayloadActions.title: "Title",
        LocalNotificationPayloadActions.identifier: "id_1",
        LocalNotificationPayloadActions.buttonType: "default",
    ],
    [
        LocalNotificationPayloadActions.title: "Title",
        LocalNotificationPayloadActions.identifier: "id_1",
        LocalNotificationPayloadActions.buttonType: "danger",
    ],
]

let actions_button_for_category_first_corrupted: [[AnyHashable: Any]] = [
    [
        LocalNotificationPayloadActions.title: "Title",
        LocalNotificationPayloadActions.buttonType: "default",
    ],
    [
        LocalNotificationPayloadActions.title: "Title",
        LocalNotificationPayloadActions.identifier: "id_2",
        LocalNotificationPayloadActions.buttonType: "danger",
    ],
]

let action_button_data_empty: [AnyHashable: Any] = [:]

let action_button_data: [AnyHashable: Any] = [
    LocalNotificationPayloadActions.title: "Title",
    LocalNotificationPayloadActions.identifier: "id_1",
    LocalNotificationPayloadActions.buttonType: "default",
]
let action_button_data_no_title: [AnyHashable: Any] = [
    LocalNotificationPayloadActions.identifier: "id_1",
    LocalNotificationPayloadActions.buttonType: "default",
]

let action_button_data_no_identifier: [AnyHashable: Any] = [
    LocalNotificationPayloadActions.title: "Title",
    LocalNotificationPayloadActions.buttonType: "default",
]
let action_button_data_destructive: [AnyHashable: Any] = [
    LocalNotificationPayloadActions.title: "Title",
    LocalNotificationPayloadActions.identifier: "id_1",
    LocalNotificationPayloadActions.buttonType: "danger",
]

let action_button_data_title_number: [AnyHashable: Any] = [
    LocalNotificationPayloadActions.title: 111,
    LocalNotificationPayloadActions.identifier: "id_1",
    LocalNotificationPayloadActions.buttonType: "danger",
]

let action_button_data_identifier_number: [AnyHashable: Any] = [
    LocalNotificationPayloadActions.title: "Title",
    LocalNotificationPayloadActions.identifier: 111,
    LocalNotificationPayloadActions.buttonType: "danger",
]

let action_button_data_corrupted_data: [AnyHashable: Any] = [
    LocalNotificationPayloadActions.title: true,
    LocalNotificationPayloadActions.identifier: true,
    LocalNotificationPayloadActions.buttonType: 123,
]

let action_is_button_destructive_empty: [AnyHashable: Any] = [:]

let action_is_button_destructive_data: [AnyHashable: Any] = [LocalNotificationPayloadActions.buttonType: LocalNotificationPayloadActions.ButtonType.danger]

let action_is_button_destructive_wrong_data: [AnyHashable: Any] = [LocalNotificationPayloadActions.buttonType: 123]

let action_is_button_destructive_data_default: [AnyHashable: Any] = [LocalNotificationPayloadActions.buttonType: LocalNotificationPayloadActions.ButtonType.default]
