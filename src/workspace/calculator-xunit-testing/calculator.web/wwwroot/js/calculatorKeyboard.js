const calculatorKeys = new Set([
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  ".",
  "+",
  "-",
  "*",
  "/",
  "%",
  "^",
]);

let keyboardHandler;

export function attachCalculatorKeyboard(dotNetReference) {
  detachCalculatorKeyboard();

  keyboardHandler = (event) => {
    let key = event.key;

    if (calculatorKeys.has(key)) {
      event.preventDefault();
    } else if (key === "Enter") {
      key = "=";
      event.preventDefault();
    } else if (
      key === "Escape" ||
      key === "Backspace" ||
      key.toLowerCase() === "c"
    ) {
      key = "clear";
      event.preventDefault();
    } else {
      return;
    }

    dotNetReference.invokeMethodAsync("HandleKeyboardInput", key);
  };

  window.addEventListener("keydown", keyboardHandler);
}

export function detachCalculatorKeyboard() {
  if (keyboardHandler) {
    window.removeEventListener("keydown", keyboardHandler);
    keyboardHandler = undefined;
  }
}
