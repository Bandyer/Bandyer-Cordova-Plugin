//
// Copyright © 2020 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

export class CordovaSpy implements Cordova {
    platformId: string;
    plugins: CordovaPlugins;
    version: string;

    readonly execInvocations: Array<ExecInvocation> = [];

    define(moduleName: string, factory: (require: any, exports: any, module: any) => any): void {
    }

    exec(success: (data: any) => any, fail: (err: any) => any, service: string, action: string, args?: any[]): void {
        const inv = new ExecInvocation(service, action, success, fail, args);
        this.execInvocations.push(inv);
    }

    simulateSuccess(data: any) {
        this.execInvocations.forEach((it) => {
            it.success(data)
        })
    }

    simulateFailure(err: any) {
        this.execInvocations.forEach((it) => {
            it.fail(err)
        })
    }

    require(moduleName: string): any {
        return null;
    }
}

export class ExecInvocation {
    readonly service: string;
    readonly action: string;
    readonly args?: any[];
    readonly success: (data: any) => any;
    readonly fail: (err: any) => any;

    constructor(service: string, action: string, success: (data: any) => any, fail: (err: any) => any, args?: any[]) {
        this.service = service;
        this.action = action;
        this.args = args;
        this.success = success;
        this.fail = fail;
    }
}