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