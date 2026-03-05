import { Link } from "react-router-dom";

export default function NotFoundPage() {
  return (
    <div className="flex min-h-[60vh] items-center justify-center px-4">
      <div className="text-center">
        <p className="text-7xl font-bold text-primary-600">404</p>
        <h1 className="mt-2 text-2xl font-bold text-gray-900">
          Page Not Found
        </h1>
        <p className="mt-2 text-gray-500">
          The page you're looking for doesn't exist.
        </p>
        <Link
          to="/"
          className="mt-6 inline-block rounded-lg bg-primary-600 px-6 py-2.5 text-sm font-medium text-white hover:bg-primary-700"
        >
          Go Home
        </Link>
      </div>
    </div>
  );
}
