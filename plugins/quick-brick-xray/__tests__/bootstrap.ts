const noop = jest.fn();

export function spyOnConsole() {
  const groupCollapsed = jest
    .spyOn(console, "groupCollapsed")
    .mockImplementation(noop);

  const groupEnd = jest.spyOn(console, "groupEnd").mockImplementation(noop);
  const trace = jest.spyOn(console, "trace").mockImplementation(noop);
  const log = jest.spyOn(console, "log").mockImplementation(noop);
  const debug = jest.spyOn(console, "debug").mockImplementation(noop);
  const info = jest.spyOn(console, "info").mockImplementation(noop);
  const warning = jest.spyOn(console, "warn").mockImplementation(noop);
  const error = jest.spyOn(console, "error").mockImplementation(noop);

  function resetSpies() {
    groupCollapsed.mockClear();
    groupEnd.mockClear();
    trace.mockClear();
    log.mockClear();
    debug.mockClear();
    info.mockClear();
    warning.mockClear();
    error.mockClear();
  }

  return {
    resetSpies,
    spies: {
      groupCollapsed,
      groupEnd,
      trace,
      log,
      debug,
      info,
      warning,
      error,
    },
  };
}
