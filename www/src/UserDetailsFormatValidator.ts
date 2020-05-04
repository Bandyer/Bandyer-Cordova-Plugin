//
// Copyright © 2020 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import {IllegalArgumentError} from "./errors/IllegalArgumentError";
import {keys} from "@bandyer/ts-transformer-type-structure";
import {UserDetails} from "./UserDetails";

export class UserDetailsFormatValidator {

    validate(format: string) {
        const keywords = this.findKeywords(format);

        if (keywords.length === 0) {
            throw new IllegalArgumentError("Could not find any keyword, at least one keyword in the format ${keyword} must be provided");
        }

        const allowedKeywords = keys<UserDetails>();

        keywords.forEach((keyword) => {
            // @ts-ignore
            if (allowedKeywords.indexOf(keyword) === -1) {
                throw new IllegalArgumentError("Declared keyword=${" + keyword + "} is not allowed. The allowedKeywords allowed are: " + allowedKeywords);
            }
        });
    }

    private findKeywords(format: string): string[] {
        const regex = /\${([\w]+)}/g
        let match;
        const matches: string[] = [];
        while ((match = regex.exec(format)) !== null) {
            if (match[1] && match[1] !== null)
                matches.push(match[1]);
        }
        return matches;
    }
}