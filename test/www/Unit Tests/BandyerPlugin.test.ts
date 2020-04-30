//
// Copyright © 2020 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import {Environments} from "../../../www/src/Environments";
import {BandyerPlugin} from "../../../www/src/BandyerPlugin";
import {CordovaSpy} from "./CordovaSpy";
import {DeviceStub} from "./DeviceStub";
import {BandyerPluginConfigs} from "../../../www/src/BandyerPluginConfigs";

describe('Plugin setup', function () {

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
    });

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

    test('Throws an invalid argument exception when running in a simulator and iOSConfiguration is missing the fake capturer filename', () =>{
        device.isVirtual = true;

        const setup = () => {
            var config = makePluginConfig();
            config.iosConfig.fakeCapturerFileName = null;
            BandyerPlugin.setup(config);
        };

        expect(setup).toThrowError(Error);
    });

    test('Calls "initializeBandyer" action with the argument provided in config parameter', () => {
        var config = {
            environment: Environments.sandbox(),
            appId: 'mAppId_a21393y2a4ada1231',
            logEnabled: true,
            androidConfig : {
                callEnabled: true,
                fileSharingEnabled: true,
                screenSharingEnabled: true,
                chatEnabled: true,
                whiteboardEnabled: true,
            },
            iosConfig : {
                voipNotificationKeyPath: 'VoIPKeyPath',
                fakeCapturerFileName: 'filename.mp4',
                callkit: {
                    enabled: true,
                    appIconName: "AppIcon",
                    ringtoneSoundName: "ringtone.mp3"
                }
            }
        }

        BandyerPlugin.setup(config);

        expect(cordovaSpy.execInvocations.length).toEqual(1);
        expect(cordovaSpy.execInvocations[0].service).toMatch('BandyerPlugin');
        expect(cordovaSpy.execInvocations[0].action).toMatch('initializeBandyer');
        expect(cordovaSpy.execInvocations[0].args).toBeDefined();
        expect(cordovaSpy.execInvocations[0].args[0]).toBeDefined();
        expect(cordovaSpy.execInvocations[0].args[0]["environment"]).toMatch('sandbox');
        expect(cordovaSpy.execInvocations[0].args[0]["appId"]).toMatch('mAppId_a21393y2a4ada1231');
        expect(cordovaSpy.execInvocations[0].args[0]["logEnabled"]).toBeTruthy();
        expect(cordovaSpy.execInvocations[0].args[0]["ios_callkit"]).toBeTruthy();
        expect(cordovaSpy.execInvocations[0].args[0]["ios_fakeCapturerFileName"]).toMatch('filename.mp4');
        expect(cordovaSpy.execInvocations[0].args[0]["ios_voipNotificationKeyPath"]).toMatch('VoIPKeyPath');
        expect(cordovaSpy.execInvocations[0].args[0]["android_isCallEnabled"]).toBeTruthy();
        expect(cordovaSpy.execInvocations[0].args[0]["android_isFileSharingEnabled"]).toBeTruthy();
        expect(cordovaSpy.execInvocations[0].args[0]["android_isScreenSharingEnabled"]).toBeTruthy();
        expect(cordovaSpy.execInvocations[0].args[0]["android_isChatEnabled"]).toBeTruthy();
        expect(cordovaSpy.execInvocations[0].args[0]["android_isWhiteboardEnabled"]).toBeTruthy();
    })
});

function makePluginConfig(): BandyerPluginConfigs {
    return {
        androidConfig: {
            callEnabled: true,
            fileSharingEnabled: true,
            screenSharingEnabled: true,
            chatEnabled: true,
            whiteboardEnabled: true,
        },
        appId: 'Some APP ID',
        environment: Environments.sandbox(),
        iosConfig: {
            voipNotificationKeyPath: 'Notification key path',
            fakeCapturerFileName: 'my-video.mp4',
            callkit : {
                appIconName: 'AppIcon',
                enabled: true,
                ringtoneSoundName: 'MyRingtone'
            },
        },
        logEnabled: false
    }
}