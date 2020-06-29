//
//  ParserDummies.swift
//  ZappCore
//
//  Created by Anton Kononenko on 1/9/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

// {
//      identifier: "action_1",
//      title: "I am a google link",
//      url: "https://www.google.com/",
//      buttonType: "default",
// }

@testable import ZappCore

let url_from_action_data: [AnyHashable: String] = [
    LocalNotificationPayloadActions.identifier: "id_1",
    LocalNotificationPayloadActions.url: "https://www.google.com/",
]

let url_from_action_data_url_empty: [AnyHashable: String] = [
    LocalNotificationPayloadActions.identifier: "id_1",
    LocalNotificationPayloadActions.url: "",
]

let url_from_action_data_url_not_exist: [AnyHashable: String] = [
    LocalNotificationPayloadActions.identifier: "id_1",
]

let actions_from_payload_empty: [AnyHashable: Any] = [:]

let actions_from_payload_data: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions: [
    [
        LocalNotificationPayloadActions.identifier: "id_1",
        LocalNotificationPayloadActions.url: "",
    ],
],
]

let actions_from_payload_incorrect_not_array: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions: [
    LocalNotificationPayloadActions.identifier: "id_1",
    LocalNotificationPayloadActions.url: "",
],
]

let actions_from_payload_data_not_dict: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions: [
    "Wrong format of the dict",
],
]

let actions_from_payload_data_wrong_dict_type: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions: [
    [
        LocalNotificationPayloadActions.identifier: 123,
        LocalNotificationPayloadActions.url: 332,
    ],
],
]

let find_url_in_actions_payload_data: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions: [
    [
        LocalNotificationPayloadActions.identifier: "id_1",
    ],
    [
        LocalNotificationPayloadActions.identifier: "id_2",
        LocalNotificationPayloadActions.url: "https://www.google.com/",
    ],
],
]

let find_url_in_actions_payload_data_empty: [AnyHashable: Any] = [LocalNotificationPayloadConst.actions: []]

let url_from_payload_for_default_key_empty: [AnyHashable: Any] = [:]

let url_from_payload_for_default_key_data: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.dismissActionUrl: "https://www.google.com/",
    LocalNotificationPayloadConst.defaultActionUrl: "https://www.google.com/",
]

let url_from_payload_for_default_key_not_wrong: [AnyHashable: Any] = [
    LocalNotificationPayloadConst.defaultActionUrl: 213,
]
