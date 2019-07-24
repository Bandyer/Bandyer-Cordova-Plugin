module.exports = function (api) {
    api.cache(true);
    const presets = [
        ["@babel/typescript"],
        ['@babel/preset-env', {
            useBuiltIns: "usage"
        }]
    ];
    const plugins = [
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