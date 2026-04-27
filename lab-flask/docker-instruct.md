1. The User Creation
Dockerfile
RUN adduser --disabled-password --gecos "" appuser
RUN: Tells Docker to execute a command during the build process.

adduser: The standard Linux command to create a new person (user) in the system.

--disabled-password: This is a security "Best Practice." It creates the user but prevents anyone from logging in with a password. Since this user only exists to run your Flask app, it doesn't need a password.

--gecos "": In the old days of Unix, "GECOS" was a field used to store the user's real name, office number, and phone number. By setting it to "" (empty), we tell the installer: "Don't ask me any questions, just create the user."

appuser: This is simply the name we chose. You could name it piyapoom or devops, but appuser is a common industry standard.

2. The Permission Change
Dockerfile
RUN chown -R appuser:appuser /app
chown: Short for Change Owner.

-R: Stand for Recursive. This is the "Naked Server" way of saying: "Don't just change the folder; change every single file and sub-folder inside it too."

appuser:appuser: This sets the Owner to appuser and the Group to appuser.

/app: The target directory where your code lives.

The "Real Job" Logic: Since you are about to switch away from the "Root" user, you must give your new user permission to read and run the code in that folder. If you skip this, your app will crash with a Permission Denied error.

3. The Security Switch
Dockerfile
USER appuser
USER: This is a Docker-specific instruction.

It tells the container: "From this point forward, stop acting as the all-powerful Root and start acting as appuser."

Why this is "Senior" level:
Imagine a hacker finds a bug in your Flask code.

Without this line: The hacker is "Root." They can delete your whole server, steal other users' data, and install viruses.

With this line: The hacker is trapped as appuser. They can't install software, they can't change system settings, and they are stuck inside your /app folder. You just saved the company from a massive disaster.

# 1. Use a specific, stable version
FROM python:3.12-slimps

# 2. Set environment variables to optimize Python performance
ENV PYTHONDONTWRITEBYTECODE=1 `Prevents Python from writing .pyc files` `you get a cleaner system, no "Ghost Bugs" from old cache, and you save disk I/O operations`
ENV PYTHONUNBUFFERED=1 `by defalt, It waits until full (usually 4KB or 8KB of text) before it dumps all the logs at once.` `With this, logs are sent straight to the terminal in real-time.`

WORKDIR /app

# System Dependencies
RUN apt-get update && \ `apt-get: original low-level tool."guaranteed" not to change between different versions of Linux.`
    apt-get install -y --no-install-recommends curl && \ `Prevents Linux from installing "extra" stuff you don't need` `-y "yes"`
    rm -rf /var/lib/apt/lists/* `Cleans up the temporary files created during the install` `-f "FORCE, Do not ask me any questions, and do not stop for any errors"`

# 3. Security: Create a non-privileged user
RUN adduser --disabled-password --gecos "" appuser `--gecos "" Do not asking for "User Profile"`

# 4. Copy only requirements first to leverage Docker caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the rest of the code
COPY . .

# 6. Change ownership to the non-root user
RUN chown -R appuser:appuser /app `-R for chown`
USER appuser

EXPOSE 5000

# 7. Use a "Healthcheck" instruction
# This tells Docker ITSELF to monitor your /health route
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:5000/health || exit 1 `-f: Fail Silently, By default, curl might return a "success" even 404 or 500` ` || is "Or"`

CMD ["python", "app.py"]