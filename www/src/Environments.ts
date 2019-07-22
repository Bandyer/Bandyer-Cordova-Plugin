/**
 * An environment where your Bandyer integration will run
 */
export interface Environment {

    /**
     * name of the environment
     */
    name: string;
}

/**
 * Bandyer available environments
 */
export class Environments implements Environment {

    /**
     * Sandbox environment
     */
    static sandbox(): Environment {
        return new Environments("sandbox");
    }

    /**
     * Production environment
     */
    static production(): Environment {
        return new Environments("production");
    }

    /**
     * name of the environment
     * @ignore
     */
    name: string;

    /**
     * @ignore
     */
    private constructor(name: string) {
        this.name = name;
    }
}
