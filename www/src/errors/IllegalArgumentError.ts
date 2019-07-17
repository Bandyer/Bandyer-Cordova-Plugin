/**
 * This error will be thrown when arguments given to a function are not of the expected type
 */
export class IllegalArgumentError extends Error {
    name: string = "IllegalArgumentError"
}