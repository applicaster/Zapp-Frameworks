import { Event } from "./Event";

type Predicate<T> = (arg: T) => boolean;
type Transformer<T> = (arg: T) => any;
type Condition = [Predicate<any>, Transformer<any>];
type AnyArray = any[];
type AnyObject = { [K in string]: any };

const REACT_COMPONENT_SYMBOL = "$$typeof";

function hasProperty(property: string, object: AnyObject): boolean {
  return Object.prototype.hasOwnProperty.call(object, property);
}

function isReactClassComponent(value: any): boolean {
  if (!isObject(value)) {
    return false;
  }

  return hasProperty(REACT_COMPONENT_SYMBOL, value);
}

function isFunction(value: any): boolean {
  return typeof value === "function";
}

function isObject(value: any): boolean {
  return typeof value === "object" && !Array.isArray(value) && value !== null;
}

function isError(prop: any): boolean {
  try {
    return prop?.constructor === Error || prop?.__proto__?.name === "Error";
  } catch (e) {
    return false;
  }
}

function cond(conditions: Condition[]) {
  return function (arg: any): any {
    let index = 0;

    while (index < conditions.length) {
      const [predicate, transform] = conditions[index];
      if (predicate(arg)) return transform(arg);
      index++;
    }

    return arg;
  };
}

function sanitizeArrayEntries(array: AnyArray): AnyArray {
  return array.map(applyConditions);
}

function sanitizeObjectProperties(object: AnyObject): AnyObject {
  return Object.keys(object).reduce((acc, curr) => {
    acc[curr] = applyConditions(object[curr]);

    return acc;
  }, {});
}

function sanitizeFunction(fn) {
  return fn?.name ? `function ${fn?.name}` : "anonymous function";
}

function sanitizeReactComponentClass(Component) {
  return Component?.displayName
    ? `Component ${Component.displayName}`
    : "React Component";
}

export function wrapInObject(object, propName) {
  if (isObject(object)) {
    return object;
  }

  return { [propName]: object };
}

export const applyConditions = cond([
  [isFunction, sanitizeFunction],
  [isReactClassComponent, sanitizeReactComponentClass],
  [Array.isArray, sanitizeArrayEntries],
  [isError, (error) => error?.message as string],
  [isObject, sanitizeObjectProperties],
]);

export function sanitizeEventPayload(event: XRayEvent) {
  try {
    const { data = {}, exception } = event;

    const nativeEvent = {
      ...event,
      data: applyConditions(wrapInObject(data, "data")),
    };

    if (exception) {
      nativeEvent.exception = applyConditions(exception);
    }

    return nativeEvent;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.warn(
      "An error occurred when trying to sanitize the native payload",
      { error, event }
    );

    return {
      ...event,
      data: {},
      context: {},
    };
  }
}

export function __isRunningRepoTests() {
  try {
    return __DEV__ && (global as any).__ZAPP_FRAMEWORKS_TESTS__;
  } catch (e) {
    return false;
  }
}
