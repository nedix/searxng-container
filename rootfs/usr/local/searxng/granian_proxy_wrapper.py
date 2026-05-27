from granian.utils.proxies import wrap_wsgi_with_proxy_headers
from searx.webapp import app as searxng_app

app = wrap_wsgi_with_proxy_headers(
    searxng_app,
    trusted_hosts=["*"]
)
