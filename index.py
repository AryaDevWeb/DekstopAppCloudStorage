# test_cloudinary.py
import cloudinary
import cloudinary.api

cloudinary.config(
    cloud_name="ddz5n7ykw",
    api_key="848311496262211",
    api_secret="F_vesavrK9leKVWsR_1sVaXIMxs"
)

try:
    print(cloudinary.api.ping())
except Exception as e:
    print(f"Error: {e}")