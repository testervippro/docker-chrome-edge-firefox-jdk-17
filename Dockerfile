FROM maven:3.8.6-eclipse-temurin-17
# Use Eclipse Temurin JDK 17 as the base image
#FROM eclipse-temurin:17

# Update and install curl and unzip
RUN apt-get update -qqy \
    && apt-get install -qqy unzip curl \
    gnupg \
    libgtk-3-0 \
    libx11-xcb1 \
    libdbus-glib-1-2 \
    libxt6 \
    libnss3 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Firefox
# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ARG CHROME_VERSION=114.0.5735.90
ARG CHROME_DRIVER_VERSION=114.0.5735.90
ARG FIREFOX_VERSION=134.0.2
ARG GECKODRIVER_VERSION=v0.35.0
ARG EDGE_VERSION_DRIVER=132.0.2957.115
RUN apt-get update -qqy \
	&& apt-get -qqy install bzip2 libgtk-3-0 libx11-xcb1 libdbus-glib-1-2 libxt6 libasound2 \
	&& rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
	&& wget -q -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
	&& tar xjf /tmp/firefox.tar.bz2 -C /opt \
	&& rm /tmp/firefox.tar.bz2 \
	&& mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
	&& ln -s /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

# Geckodriver

RUN wget -q -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/$GECKODRIVER_VERSION/geckodriver-$GECKODRIVER_VERSION-linux64.tar.gz \
	&& tar xzf /tmp/geckodriver.tar.gz -C /opt \
	&& rm /tmp/geckodriver.tar.gz \
	&& mv /opt/geckodriver /opt/geckodriver-$GECKODRIVER_VERSION \
	&& ln -s /opt/geckodriver-$GECKODRIVER_VERSION /usr/bin/geckodriver



# Set Chrome and ChromeDriver versions
ARG CHROME_VERSION=132.0.6834.83
ARG CHROME_URL=https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chrome-linux64.zip
ARG CHROMEDRIVER_URL=https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip

# Install Google Chrome
RUN mkdir -p /opt/chrome \
    && curl -sSL $CHROME_URL -o /tmp/chrome.zip \
    && unzip /tmp/chrome.zip -d /opt/chrome \
    && rm /tmp/chrome.zip \
    && ln -s /opt/chrome/chrome-linux64/chrome /usr/bin/google-chrome

# Install ChromeDriver
RUN mkdir -p /opt/chromedriver \
    && curl -sSL $CHROMEDRIVER_URL -o /tmp/chromedriver.zip \
    && unzip /tmp/chromedriver.zip -d /opt/chromedriver \
    && rm /tmp/chromedriver.zip \
    && ln -s /opt/chromedriver/chromedriver-linux64/chromedriver /usr/bin/chromedriver

  
# # # Install Microsoft Edge WebDriver (Ok)
# RUN mkdir -p /opt/edgedriver \
#     && curl -sSL "https://msedgedriver.azureedge.net/$EDGE_VERSION_DRIVER/edgedriver_linux64.zip" -o /tmp/edgedriver.zip \
#     && unzip /tmp/edgedriver.zip -d /opt/edgedriver \
#     && rm /tmp/edgedriver.zip \
#     && ln -s /opt/edgedriver/edgedriver-linux64/edgedriver /usr/bin/edgedriver
# Download the Edge WebDriver
RUN mkdir -p /opt/msedgedriver \
    && curl -sSL https://msedgedriver.azureedge.net/132.0.2957.115/edgedriver_linux64.zip -o /tmp/msedgedriver.zip \
    && unzip /tmp/msedgedriver.zip -d /opt/msedgedriver \
    && rm /tmp/msedgedriver.zip \
    && chmod +x /opt/msedgedriver/msedgedriver \
    && ln -s /opt/msedgedriver/msedgedriver /usr/bin/msedgedriver

# Download and install Microsoft Edge stable version 132.0.2957.115-1
# Add the Microsoft Edge repository
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list

# Install Microsoft Edge
RUN apt-get update && apt-get install -y microsoft-edge-stable \
    && rm -rf /var/lib/apt/lists/*

    # Verify browser and driver installations
# Verify browser and driver installations when container runs
ENTRYPOINT google-chrome --version && \
    chromedriver --version && \
    firefox --version && \
    geckodriver --version && \
    microsoft-edge --version && \
    msedgedriver --version && \
    tail -f /dev/null


# Set default command to a shell (or any other command you prefer)
CMD ["/bin/bash"]    
