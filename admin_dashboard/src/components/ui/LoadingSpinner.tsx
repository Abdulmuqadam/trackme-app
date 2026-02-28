export default function LoadingSpinner({ size = 8 }: { size?: number }) {
  return (
    <div className="flex items-center justify-center py-12">
      <div
        className={`h-${size} w-${size} animate-spin rounded-full border-4 border-red-600 border-t-transparent`}
      />
    </div>
  );
}
