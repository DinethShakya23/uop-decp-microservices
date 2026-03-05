export default function Footer() {
  return (
    <footer className="border-t border-gray-200 bg-white py-6">
      <div className="mx-auto max-w-7xl px-4 text-center text-sm text-gray-500">
        <p>
          &copy; {new Date().getFullYear()} DECP &mdash; Department Engagement
          &amp; Career Platform
        </p>
        <p className="mt-1">
          University of Peradeniya &middot; CO528 Applied Software Architecture
        </p>
      </div>
    </footer>
  );
}
