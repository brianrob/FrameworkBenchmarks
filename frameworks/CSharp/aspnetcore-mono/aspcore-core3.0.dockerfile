FROM debian:stretch-20181226

# Install tools and dependencies.
RUN apt-get update && \
    apt-get install -y \
        apt-transport-https \
        dirmngr \
        gnupg \
        ca-certificates \
        make \
        git \
        gcc \
        g++ \
        autoconf \
        libtool \
        automake \
        cmake \
        gettext \
        python \
        libunwind8 \
        icu-devtools

# Download and install the .NET Core SDK.
WORKDIR /dotnet
RUN curl -OL https://download.visualstudio.microsoft.com/download/pr/4f51cfd8-311d-43fe-a887-c80b40358cfd/440d10dc2091b8d0f1a12b7124034e49/dotnet-sdk-3.0.101-linux-x64.tar.gz && \
    tar -xzvf dotnet-sdk-3.0.101-linux-x64.tar.gz
ENV PATH=${PATH}:/dotnet

# Clone the test repo.
WORKDIR /src
RUN git clone https://github.com/brianrob/aspnetcore && \
    cd aspnetcore && \
    git checkout 3.0.1

# Build the app.
ENV BenchmarksTargetFramework netcoreapp3.0
ENV MicrosoftAspNetCoreAppPackageVersion 3.0.1
ENV MicrosoftNETCoreAppPackageVersion 3.0.1
WORKDIR /src/aspnetcore/src/Servers/Kestrel/perf/PlatformBenchmarks
RUN dotnet publish -c Release -f netcoreapp3.0 --self-contained -r linux-x64

# Run the test.
WORKDIR /src/aspnetcore/src/Servers/Kestrel/perf/PlatformBenchmarks/bin/Release/netcoreapp3.0/linux-x64/publish
ENV ASPNETCORE_URLS http://+:8080
CMD ["./PlatformBenchmarks"]
