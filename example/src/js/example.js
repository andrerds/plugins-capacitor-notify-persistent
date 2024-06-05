import { NotifyPersistent } from 'capacitor-notify-persistent';


window?.testEcho = () => {
    const inputValue = document?.getElementById("echoInput").value;
    NotifyPersistent.echo({ value: inputValue })
}
