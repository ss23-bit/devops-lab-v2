**Summarizing Service Discovery**
Service Discovery is how containers find each other without you needing to know their internal IP addresses (which change every time a container restarts).

Using your Redis example, here is how the "magic" happens:

*The Registration:* When Docker starts the redis-db container, it registers that name in its internal Embedded DNS server.

*The Request:* Your Python code says: "Connect to REDIS_HOST". Because you set that variable to redis-db, the code sends a request to the network asking: "Where is the server named redis-db?"

*The Resolution:* Docker’s DNS intercepts this request. It looks at its list, sees that redis-db is at internal IP 172.18.0.3, and points your app to that IP.

*The Handshake:* Your app connects successfully, even though you never typed a single IP address.

*Key Takeaway:* You treat the Service Name in your YAML file exactly like a URL (like google.com). As long as they are on the same Docker network, Docker handles the "phonebook" lookup for you.