/** @type {import('next').NextConfig} */
const nextConfig = {
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: "http://localhost:3000/api/:path*", // Adjust if your backend runs elsewhere
      },
    ];
  },
  reactStrictMode: true,
};

module.exports = nextConfig;
