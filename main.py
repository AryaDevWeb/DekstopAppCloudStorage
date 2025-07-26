import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
import customtkinter as ctk
from views.auth_view import AuthView
from views.main_view import MainView
from views.register_view import RegisterView

class NebulaApp:
    def __init__(self, root):
        self.root = root
        self.root.title("CloudFort Storage")
        self.root.geometry("1100x700")
        self.root.minsize(900, 600)
        
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")
        
        self.container = ctk.CTkFrame(root)
        self.container.pack(fill="both", expand=True)
        
        self.current_view = None
        self.current_username = None
        self.show_auth_view()
    
    def show_auth_view(self):
        if self.current_view:
            self.current_view.destroy()
        self.current_view = AuthView(self.container, self, self.handle_login_success)
        self.current_view.pack(fill="both", expand=True)

    def show_register_view(self):
        if self.current_view:
            self.current_view.destroy()
        self.current_view = RegisterView(self.container, self, self.show_auth_view, self.show_auth_view)
        self.current_view.pack(fill="both", expand=True)
    
    def show_main_view(self, username):
        if self.current_view:
            self.current_view.destroy()
        self.current_username = username
        self.current_view = MainView(self.container, username, self.handle_logout, self.handle_switch_account)
        self.current_view.pack(fill="both", expand=True)
    
    def handle_login_success(self, username):
        self.show_main_view(username)
    
    def handle_logout(self):
        if os.path.exists("session.json"):
            os.remove("session.json")
        self.show_auth_view()
        self.current_username = None
    
    def handle_switch_account(self):
        if os.path.exists("session.json"):
            os.remove("session.json")
        self.show_auth_view()
        self.current_username = None

if __name__ == "__main__":
    root = ctk.CTk()
    app = NebulaApp(root)
    root.mainloop()