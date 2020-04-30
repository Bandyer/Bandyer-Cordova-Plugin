import {IllegalArgumentError} from "../errors/IllegalArgumentError";

export const matchGroup = (text: string, regex: RegExp, index: number) => {
    let match;
    const matches: string[] = [];
    while (match = regex.exec(text)) {
        matches.push(match[index]);
    }
    return matches;
};

export const validateKeywords = (expected, actual) => {
    if (!actual) {
        return;
    }
    actual.forEach((key) => {
        if (expected.indexOf(key) === -1) {
            throw new IllegalArgumentError("Declared keyword=${" + key + "} is not allowed. The keywords allowed are: " + expected);
        }
    });
};
