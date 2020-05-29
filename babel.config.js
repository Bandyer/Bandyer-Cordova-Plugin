module.exports = function (api) {
    api.cache(true);
    const presets = [
        ["@babel/typescript"],
        ['@babel/preset-env', {
            useBuiltIns: "usage",
            targets: {node: 'current'}
        }],
        ["@babel/preset-typescript"]
    ];
    const plugins = [
        ["@babel/plugin-proposal-decorators", {"legacy": true}],
        ["@babel/plugin-proposal-class-properties", {"legacy": true}],
        ["@babel/plugin-transform-spread"],
        ['@babel/plugin-transform-runtime', {
            helpers: true,
            regenerator: true,
            useESModules: false
        }]
    ];
    return {
        presets,
        plugins
    }
};