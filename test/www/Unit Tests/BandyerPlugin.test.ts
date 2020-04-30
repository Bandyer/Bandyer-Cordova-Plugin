import {Environments} from "../../../www/src/Environments";
import {BandyerPlugin} from "../../../www/src/BandyerPlugin";
import {CordovaSpy} from "./CordovaSpy";
import {DeviceStub} from "./DeviceStub";

beforeEach(() => {
    globalThis.device = new DeviceStub();
    globalThis.cordova = new CordovaSpy();
});

afterEach(() => {
    globalThis.device = undefined;
    globalThis.cordova = undefined;
});

test('Throws an invalid argument exception when appId parameter is missing', () => {
    const plugin = () => {
        // @ts-ignore
        BandyerPlugin.setup({
            androidConfig: {},
            environment: Environments.sandbox(),
            iosConfig: {voipNotificationKeyPath: ""},
            logEnabled: false
        })
    };

    expect(plugin).toThrowError(Error);
});

test('Throws an invalid argument exception when appId is empty', () => {
    const plugin = () => {
        BandyerPlugin.setup({
            androidConfig: {},
            appId: "",
            environment: Environments.sandbox(),
            iosConfig: {voipNotificationKeyPath: ""},
            logEnabled: false
        })
    };

    expect(plugin).toThrowError(Error);
});