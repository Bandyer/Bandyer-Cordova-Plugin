//
// Copyright © 2020 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import {Environments} from "../../../www/src/Environments";
import {BandyerPlugin} from "../../../www/src/BandyerPlugin";
import {CordovaSpy} from "./CordovaSpy";
import {DeviceStub} from "./DeviceStub";
import {BandyerPluginConfigs} from "../../../www/src/BandyerPluginConfigs";
import {CallType} from "../../../www/src/CallType";
import {CallDisplayMode} from "../../../www/src/CallDisplayMode";

let device: DeviceStub;
let cordovaSpy: CordovaSpy;

beforeEach(() => {
    device = new DeviceStub();
    cordovaSpy = new CordovaSpy();
    globalThis.device = device;
    globalThis.cordova = cordovaSpy;
});

afterEach(() => {
    globalThis.device = undefined;
    globalThis.cordova = undefined;
    BandyerPlugin.instance = undefined;
});

describe('Plugin setupAsync', function () {

    test('Promise fails when called with invalid arguments', (done) => {
        const config: BandyerPluginConfigs = makePluginConfig();
        config.appId = undefined;
        const promise = BandyerPlugin.setupAsync(config);
        promise.then(() => {
                fail("This should fail");
                done();
            },
            (err) => {
                done()
            });
    });
});

describe('Plugin setup', function () {

    test('Throws an invalid argument exception when appId parameter is missing', () => {
        const setup = () => {
            // @ts-ignore
            BandyerPlugin.setup({
                androidConfig: {},
                environment: Environments.sandbox(),
                iosConfig: {voipNotificationKeyPath: ""},
                logEnabled: false
            })
        };

        expect(setup).toThrowError(Error);
    });

    test('Throws an invalid argument exception when appId is empty', () => {
        const setup = () => {
            var config = makePluginConfig();
            config.appId = "";
            BandyerPlugin.setup(config);
        };

        expect(setup).toThrowError(Error);
    });

    test('Throws an invalid argument exception when running in a simulator and iOSConfiguration is missing the fake capturer filename', () => {
        device.simulateVirtual();

        const setup = () => {
            var config = makePluginConfig();
            config.iosConfig.fakeCapturerFileName = null;
            BandyerPlugin.setup(config);
        };

        expect(setup).toThrowError(Error);
    });

    test('Calls "initializeBandyer" action with the argument provided in config parameter', () => {
        const config = {
            environment: Environments.sandbox(),
            appId: 'mAppId_a21393y2a4ada1231',
            logEnabled: true,
            androidConfig: {
                callEnabled: true,
                fileSharingEnabled: true,
                screenSharingEnabled: true,
                chatEnabled: true,
                whiteboardEnabled: true,
                keepListeningForEventsInBackground: true,
            },
            iosConfig: {
                voipNotificationKeyPath: 'VoIPKeyPath',
                fakeCapturerFileName: 'filename.mp4',
                callkit: {
                    enabled: true,
                    appIconName: "AppIcon",
                    ringtoneSoundName: "ringtone.mp3"
                }
            }
        };

        BandyerPlugin.setup(config);

        expect(cordovaSpy.execInvocations.length).toEqual(1);

        const invocation = cordovaSpy.execInvocations[0];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('initializeBandyer');
        expect(invocation.args).toBeDefined();

        const firstArg = invocation.args[0];
        expect(firstArg).toBeDefined();
        expect(firstArg["environment"]).toMatch('sandbox');
        expect(firstArg["appId"]).toMatch('mAppId_a21393y2a4ada1231');
        expect(firstArg["logEnabled"]).toEqual(true);

        expect(firstArg["ios_callkit"]["enabled"]).toEqual(true);
        expect(firstArg["ios_callkit"]["appIconName"]).toMatch("AppIcon");
        expect(firstArg["ios_callkit"]["ringtoneSoundName"]).toMatch("ringtone.mp3");
        expect(firstArg["ios_fakeCapturerFileName"]).toMatch('filename.mp4');
        expect(firstArg["ios_voipNotificationKeyPath"]).toMatch('VoIPKeyPath');

        expect(firstArg["android_isCallEnabled"]).toEqual(true);
        expect(firstArg["android_isFileSharingEnabled"]).toEqual(true);
        expect(firstArg["android_isScreenSharingEnabled"]).toEqual(true);
        expect(firstArg["android_isChatEnabled"]).toEqual(true);
        expect(firstArg["android_isWhiteboardEnabled"]).toEqual(true);
        expect(firstArg["android_keepListeningForEventsInBackground"]).toEqual(true);
    });

    test('When running on generic device, calls "initializeBandyer" action with the mandatory only arguments provided in config parameter', () => {
        const config = {
            environment: Environments.sandbox(),
            appId: 'mAppId_a21393y2a4ada1231'
        };

        BandyerPlugin.setup(config);

        expect(cordovaSpy.execInvocations.length).toEqual(1);

        const invocation = cordovaSpy.execInvocations[0];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('initializeBandyer');
        expect(invocation.args).toBeDefined();

        const firstArg = invocation.args[0];
        expect(firstArg).toBeDefined();
        expect(firstArg["environment"]).toMatch('sandbox');
        expect(firstArg["appId"]).toMatch('mAppId_a21393y2a4ada1231');
        expect(firstArg["logEnabled"]).toEqual(false);

        expect(firstArg["ios_callkit"]["enabled"]).toEqual(true);
        expect(firstArg["ios_callkit"]["appIconName"]).toBeUndefined();
        expect(firstArg["ios_callkit"]["ringtoneSoundName"]).toBeUndefined();
        expect(firstArg["ios_fakeCapturerFileName"]).toBeUndefined();
        expect(firstArg["ios_voipNotificationKeyPath"]).toBeUndefined();

        expect(firstArg["android_isCallEnabled"]).toEqual(true);
        expect(firstArg["android_isFileSharingEnabled"]).toEqual(true);
        expect(firstArg["android_isScreenSharingEnabled"]).toEqual(true);
        expect(firstArg["android_isChatEnabled"]).toEqual(true);
        expect(firstArg["android_isWhiteboardEnabled"]).toEqual(true);
        expect(firstArg["android_keepListeningForEventsInBackground"]).toEqual(false);
    });

    test('When running on iOS simulator, throws an error if fakeCapturerFileName mandatory parameter is missing during plugin setup', () => {
        device.simulateVirtual();
        device.simulateiOS();
        const config = {
            environment: Environments.sandbox(),
            appId: 'mAppId_a21393y2a4ada1231'
        };

        const setup = () => {
            BandyerPlugin.setup(config);
        };

        expect(setup).toThrowError("Expected a valid file name to initialize the fake capturer on a simulator!");
    });
});

describe('Plugin start', () => {

    test('Throws an illegal argument error when user alias is empty', () => {
        const sut = makeSUT();

        const start = () => {
            sut.startFor("")
        };

        expect(start).toThrowError(Error);
    });

    test('Calls start action with the user alias provided', () => {
        const sut = makeSUT();

        sut.startFor("usr_12345");

        expect(cordovaSpy.execInvocations.length).toEqual(2);

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('start');
        expect(invocation.args).toBeDefined();
        expect(invocation.args[0]["userAlias"]).toMatch('usr_12345');
    });
});

describe('Plugin stop', () => {

    test('Calls stop action with an empty argument list', () => {
        const sut = makeSUT();

        sut.stop();

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('stop');
        expect(invocation.args).toEqual([]);
    });
});

describe('Plugin pause', () => {

    test('Calls pause action with an empty argument list', () => {
        const sut = makeSUT();

        sut.pause();

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('pause');
        expect(invocation.args).toEqual([]);
    });
});

describe('Plugin resume', () => {

    test('Calls resume action with an empty argument list', () => {
        const sut = makeSUT();

        sut.resume();

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('resume');
        expect(invocation.args).toEqual([]);
    });
});

describe('Plugin state', () => {

    test('Calls state action with an empty argument list', () => {
        const sut = makeSUT();

        sut.state();

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('state');
        expect(invocation.args).toEqual([]);
    });
});

describe('Starting a call', () => {

    test('Throws invalid argument error when empty user alias array is provided', () => {
        const sut = makeSUT();

        const options = {
            userAliases: [],
            callType: CallType.AUDIO_VIDEO
        };

        const start = () => {
            sut.startCall(options);
        };

        expect(start).toThrowError(Error);
    });

    test('Throws invalid argument error when any user alias is an empty string', () => {
        const sut = makeSUT();

        const options = {
            userAliases: ["bob", "alice", ""],
            callType: CallType.AUDIO_VIDEO
        };

        const start = () => {
            sut.startCall(options);
        };

        expect(start).toThrowError(Error);
    });

    test('Throws an assertion error when the argument provided is missing required field', () => {
        const sut = makeSUT();

        const options = {
            callType: CallType.AUDIO_VIDEO
        };

        const start = () => {
            // @ts-ignore
            sut.startCall(options);
        };

        expect(start).toThrowError(Error);
    });

    test('Calls startCall action providing the call options as arguments', () => {
        const sut = makeSUT();

        const options = {
            recording: true,
            userAliases: ["bob", "alice"],
            callType: CallType.AUDIO_VIDEO
        };

        sut.startCall(options);

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('startCall');
        expect(invocation.args).toHaveLength(1);
        expect(invocation.args).toContainEqual({
            callee: ["bob", "alice"],
            callType: "audioVideo",
            recording: true
        });
    });

    test('Throws an invalid argument error when the provided URL is an empty string', () => {
        const sut = makeSUT();

        const start = () => {
            sut.startCallFrom("");
        };

        expect(start).toThrowError(Error);
    });

    test('Call startCall action with the provided URL as argument', () => {
        const sut = makeSUT();

        sut.startCallFrom("https://acme.bandyer.com/call/12345")

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('startCall');
        expect(invocation.args).toContainEqual({
            joinUrl: "https://acme.bandyer.com/call/12345"
        })
    });
});

describe('In call user verification', () => {

    test('When running on Android device, calls verifyCurrentCall with the argument provided as verification object parameter', () => {
        device.simulateAndroid();
        const sut = makeSUT();

        sut.verifyCurrentCall(true);

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('verifyCurrentCall');
        expect(invocation.args).toContainEqual({
            verifyCall: true
        })
    });
});

describe('Call display mode', () => {

    test('When running on Android device, calls "setDisplayModeForCurrentCall" providing the mode received as first argument', () => {
        device.simulateAndroid();
        const sut = makeSUT();

        sut.setDisplayModeForCurrentCall(CallDisplayMode.FOREGROUND_PICTURE_IN_PICTURE);

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('setDisplayModeForCurrentCall');
        expect(invocation.args).toContainEqual({
            displayMode: "FOREGROUND_PICTURE_IN_PICTURE"
        })
    });
});

describe('User details', function () {

    test('Throws invalid argument error when adding an empty array', () => {
        const sut = makeSUT();

        const addDetails = () => {
            sut.addUsersDetails([]);
        };

        expect(addDetails).toThrowError(Error);
    });

    test('Calls "addUsersDetails" action providing the user details received as arguments', () => {
        const sut = makeSUT();

        const userDetails = [
            {userAlias: "usr_12345", firstName: "Alice", lastName: "Appleseed"},
            {userAlias: "usr_54321", firstName: "Bob", lastName: "Appleseed"},
        ];
        sut.addUsersDetails(userDetails);

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('addUsersDetails');
        expect(invocation.args).toContainEqual({
            details: [
                {userAlias: "usr_12345", firstName: "Alice", lastName: "Appleseed"},
                {userAlias: "usr_54321", firstName: "Bob", lastName: "Appleseed"},
            ]
        })
    });

    test('Throws assertion error when any user detail entry is missing required field', () => {
        const sut = makeSUT();

        const addDetails = () => {
            // @ts-ignore
            sut.addUsersDetails([{firstName: 'Foo', lastName: 'Bar'}]);
        };

        expect(addDetails).toThrowError(Error);
    });

    test('Calls "removeUsersDetails" action with an empty argument list', () => {
        const sut = makeSUT();

        sut.removeUsersDetails();

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('removeUsersDetails');
        expect(invocation.args).toHaveLength(0);
    });

    test('Throws invalid argument error when "default format" does not contain any keyword matching any "UserDetails" property', () => {
        const sut = makeSUT();

        const setFormat = () => {
            sut.setUserDetailsFormat({
                default: "{fooBar}",
            })
        };

        expect(setFormat).toThrowError(Error);
    });

    test('Throws invalid argument error when "default format" contains some keyword not matching any "UserDetails" property', () => {
        const sut = makeSUT();

        const setFormat = () => {
            sut.setUserDetailsFormat({
                default: "${firstName} ${fooBar}",
            })
        };

        expect(setFormat).toThrowError(Error);
    });

    test('Throws invalid argument error when "default format" does not contain any keyword in the format {KEYWORD_NAME}', () => {
        const sut = makeSUT();

        const setFormat = () => {
            sut.setUserDetailsFormat({
                default: "{fooBar",
            })
        };

        expect(setFormat).toThrowError(Error);
    });

    test('Throws invalid argument error when "android notification format" does not contain any keyword matching any "UserDetails" property', () => {
        const sut = makeSUT();

        const setFormat = () => {
            sut.setUserDetailsFormat({
                default: "${firstName} ${lastName}",
                android_notification: "{fooBar}"
            })
        };

        expect(setFormat).toThrowError(Error);
    });

    test('Throws invalid argument error when "android notification format" contains some keyword not matching any "UserDetails" property', () => {
        const sut = makeSUT();

        const setFormat = () => {
            sut.setUserDetailsFormat({
                default: "${firstName} ${lastName}",
                android_notification: "${fooBar}"
            })
        };

        expect(setFormat).toThrowError(Error);
    });

    test('Throws invalid argument error when "android notification format" does not contain any keyword in the format {KEYWORD_NAME}', () => {
        const sut = makeSUT();

        const setFormat = () => {
            sut.setUserDetailsFormat({
                default: "${firstName} ${lastName}",
                android_notification: "${fooBar"
            })
        };

        expect(setFormat).toThrowError(Error);
    });

    test('Calls "setUserDetailsFormat" action providing the formats received as argument', () => {
        const sut = makeSUT();

        sut.setUserDetailsFormat({
            default: "${firstName} ${lastName}",
            android_notification: "${firstName} ${lastName}"
        });

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('setUserDetailsFormat');
        expect(invocation.args).toContainEqual({
            format: "${firstName} ${lastName}",
            android_notification_format: "${firstName} ${lastName}",
        });
    });

    test('When running an Android device, calls "clearUserCache" action when asked to clear the user cache', () => {
        device.simulateAndroid();
        const sut = makeSUT();

        sut.clearUserCache();

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('clearUserCache');
        expect(invocation.args).toHaveLength(0);
    });
});

describe('Push notifications handling', () => {

    test('Throws an invalid argument error when an empty payload is provided as argument', () => {
        const sut = makeSUT();

        const handleNotification = () => {
            sut.handlePushNotificationPayload("");
        };

        expect(handleNotification).toThrowError(Error);
    });

    test('Calls "handlePushNotificationPayload" with the payload received as argument', () => {
        const sut = makeSUT();

        sut.handlePushNotificationPayload("Some push payload");

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('handlePushNotificationPayload');
        expect(invocation.args).toContainEqual({
            payload: "Some push payload"
        });
    });
});

describe('Starting a chat', () => {

    test('Throws an invalid argument error when an empty user alias is provided as argument', () => {
        const sut = makeSUT();

        const startChat = () => {
            sut.startChat({
                userAlias: ""
            });
        };

        expect(startChat).toThrowError(Error);
    });

    test('Calls "startChat" action with the call options provided as its arguments', () => {
        const sut = makeSUT();

        sut.startChat({
            userAlias: "bob",
            withAudioCallCapability: {recording: false},
            withAudioUpgradableCallCapability: {recording: false},
            withAudioVideoCallCapability: {recording: false}
        });

        const invocation = cordovaSpy.execInvocations[1];
        expect(invocation.service).toMatch('BandyerPlugin');
        expect(invocation.action).toMatch('startChat');
        expect(invocation.args).toContainEqual({
            userAlias: "bob",
            audio: {recording: false},
            audioUpgradable: {recording: false},
            audioVideo: {recording: false}
        });
    });
});

function makeSUT() {
    return BandyerPlugin.setup(makePluginConfig());
}

function makePluginConfig(): BandyerPluginConfigs {
    return {
        androidConfig: {
            callEnabled: true,
            fileSharingEnabled: true,
            screenSharingEnabled: true,
            chatEnabled: true,
            whiteboardEnabled: true,
            keepListeningForEventsInBackground: true,
        },
        appId: 'Some APP ID',
        environment: Environments.sandbox(),
        iosConfig: {
            voipNotificationKeyPath: 'Notification key path',
            fakeCapturerFileName: 'my-video.mp4',
            callkit: {
                appIconName: 'AppIcon',
                enabled: true,
                ringtoneSoundName: 'MyRingtone'
            },
        },
        logEnabled: false
    }
}