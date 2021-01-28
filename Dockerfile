# ================================
# Build image
# ================================
FROM swift:5.3 AS build
LABEL stage=intermediate

WORKDIR /build
COPY Package.resolved .
COPY Package.swift .

RUN swift package resolve

COPY Sources ./Sources
COPY Tests ./Tests

RUN swift build --enable-test-discovery -c release -Xswiftc -g

# Switch to the staging area
WORKDIR /staging
# Copy main executable to staging area
RUN cp "$(swift build --enable-test-discovery --package-path /build -c release --show-bin-path)/PostFeederRun" ./
# Uncomment the next line if you need to load resources from the `Public` directory.
# Ensure that by default, neither the directory nor any of its contents are writable.
#RUN mv /build/Public ./Public && chmod -R a-w ./Public
