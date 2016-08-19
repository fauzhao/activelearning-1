function getkeypress(h,evt)
    global keypress;
    keypress = evt.Key;
    disp(['Pressed ' keypress])
end