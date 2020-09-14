type Predicate<T> = (arg: T) => boolean;
type Transformer<T> = (arg: T) => any;
type Condition = [Predicate<any>, Transformer<any>];
type AnyArray = any[];
type AnyObject = { [K in string]: any };
type EventData = {
  [K in "data"]?: any;
};

function hasProperty(property: string, object: AnyObject): boolean {
  return Object.prototype.hasOwnProperty.call(object, property);
}

function isReactClassComponent(value: any): boolean {
  if (!isObject(value)) {
    return false;
  }

  return hasProperty("$$typeof", value) && hasProperty("displayName", value);
}

function isFunction(value: any): boolean {
  return typeof value === "function";
}

function isObject(value: any): boolean {
  return typeof value === "object" && value !== null;
}

function True(_: any): boolean {
  return true;
}

function cond(conditions: Condition[]) {
  return function (arg: any): any {
    let index = 0;

    while (index < conditions.length) {
      const [predicate, transform] = conditions[index];

      if (predicate(arg)) {
        return transform(arg);
      }

      index++;
    }
  };
}

const applyConditions = cond([
  [isFunction, (value) => `function ${value?.name}` || "anonymous function"],
  [isReactClassComponent, (value) => `Component ${value.displayName}`],
  [Array.isArray, sanitizeArrayEntries],
  [isObject, sanitizeObjectProperties],
  [True, (value) => value],
]);

function sanitizeArrayEntries(array: AnyArray): AnyArray {
  return array.map(applyConditions);
}

function sanitizeObjectProperties(object: AnyObject): AnyObject {
  return Object.keys(object).reduce((acc, curr) => {
    acc[curr] = applyConditions(object[curr]);

    return acc;
  }, {});
}

export function sanitizeEventData(event: EventData) {
  if (!event?.data) {
    return event;
  }

  return {
    ...event,
    data: applyConditions(event.data),
  };
}
