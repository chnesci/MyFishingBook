# main.py
from kivy.app import App
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.boxlayout import BoxLayout
import requests

class MyFishingApp(App):
    def build(self):
        # Configurando la interfaz
        self.layout = BoxLayout(orientation='vertical')

        self.label = Label(text="Bienvenido a My Fishing Log!")
        self.layout.add_widget(self.label)

        self.button = Button(text="Obtener Log de Pesca")
        self.button.bind(on_press=self.get_fishing_log)
        self.layout.add_widget(self.button)

        return self.layout

    def get_fishing_log(self, instance):
        # Aquí puedes llamar a tu backend Flask, por ejemplo:
        try:
            response = requests.get("http://tu_backend.com/api/logs")
            if response.status_code == 200:
                # Supongamos que la respuesta es un JSON
                fishing_log = response.json()
                self.label.text = f"Último log: {fishing_log['last_log']}"
            else:
                self.label.text = "Error al obtener el log."
        except requests.exceptions.RequestException as e:
            self.label.text = f"Error: {str(e)}"

if __name__ == "__main__":
    MyFishingApp().run()
