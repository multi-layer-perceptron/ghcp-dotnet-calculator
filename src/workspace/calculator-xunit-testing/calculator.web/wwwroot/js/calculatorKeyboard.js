let keyHandler;

export function attachCalculatorKeyboard(dotNetReference) {
    detachCalculatorKeyboard();

    keyHandler = (event) => {
        const supportedKeys = new Set([
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
            ".", "+", "-", "*", "/", "%", "^", "=", "Enter",
            "Backspace", "Delete", "C", "c"
        ]);

        if (!supportedKeys.has(event.key)) {
            return;
        }

        event.preventDefault();
        dotNetReference.invokeMethodAsync("HandleKeyboardInput", event.key);
    };

    window.addEventListener("keydown", keyHandler);
}

export function detachCalculatorKeyboard() {
    if (!keyHandler) {
        return;
    }

    window.removeEventListener("keydown", keyHandler);
    keyHandler = undefined;
}