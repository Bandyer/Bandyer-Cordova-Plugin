export class CordovaStub implements Cordova {
    exec(success: (data: any) => any, fail: (err: any) => any, service: string, action: string, args?: any[]): void {
    }

    platformId: string = "";

    version: string = "";

    define(moduleName: string, factory: (require: any, exports: any, module: any) => any): void {
    }

    require(moduleName: string): any {
    }

    plugins: CordovaPlugins = {}

}
