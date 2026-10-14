import { useState } from "react";

// Como nginx actúa como proxy inverso de /app/api hacia el contenedor backend,
// el frontend puede enviar las peticiones a una ruta relativa al origen desde el que se accede
// (Si se fija localhost en el código, las peticiones no llegarán al acceder desde otro host, como en Codespace)
const API_URL = "/app/api";

export function App() {
  const [inputText, setInputText] = useState("");
  const [result, setResult] = useState("");

  const handleSend = async () => {
    if (!inputText) return;

    try {
      const response = await fetch(API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ input_text: inputText }),
      });

      if (!response.ok) {
        throw new Error("Se ha producido un error de API");
      }

      const data = await response.json();
      setResult(`Respuesta: ${data.reply}`);
    } catch (error) {
      console.error(error);
      setResult("La comunicación ha fallado.");
    }
  };

  return (
    <>
      <h1>Docker Compose Demo</h1>
      <input
        type="text"
        placeholder="Escribe un mensaje"
        value={inputText}
        onChange={(e) => setInputText(e.target.value)}
      />
      <button onClick={handleSend}>Enviar</button>
      <p>{result}</p>
    </>
  );
}
