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
});

function makePluginConfig(): BandyerPluginConfigs {
    return {
        androidConfig: {},
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