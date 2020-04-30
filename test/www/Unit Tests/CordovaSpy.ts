export class CordovaSpy implements Cordova {
    platformId: string;
    plugins: CordovaPlugins;
    version: string;

    define(moduleName: string, factory: (require: any, exports: any, module: any) => any): void {
    }

    exec(success: (data: any) => any, fail: (err: any) => any, service: string, action: string, args?: any[]): void {
    }

    require(moduleName: string): any {
        return null;
    }
}
