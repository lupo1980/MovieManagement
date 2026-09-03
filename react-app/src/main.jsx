import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';

function MovieTable({ initialPage, onPageChange }) {
  const [page, setPage] = useState(initialPage);
  const movies = page.data || [];

  function changePage(nextPage) {
    if (nextPage < 1 || nextPage === page.page) {
      return;
    }
    setPage({ ...page, page: nextPage });
    onPageChange(nextPage);
  }

  return (
    <section aria-label="Movie browser">
      <table>
        <thead>
          <tr><th>Title</th><th>Genre</th><th>IMDb rating</th></tr>
        </thead>
        <tbody>
          {movies.map((movie) => (
            <tr key={`${movie.Name}-${movie.IMDB_Rating}`}>
              <td>{movie.Name}</td>
              <td>{movie.Genre || 'Unknown'}</td>
              <td>{movie.IMDB_Rating ?? 'Not rated'}</td>
            </tr>
          ))}
        </tbody>
      </table>
      {movies.length === 0 && <p>No movies found.</p>}
      <div>
        <button type="button" disabled={page.page <= 1} onClick={() => changePage(page.page - 1)}>Previous</button>
        <span>Page {page.page}</span>
        <button type="button" disabled={page.page * page.perPage >= page.totalItems} onClick={() => changePage(page.page + 1)}>Next</button>
      </div>
    </section>
  );
}

export function mount(element, initialPage, callbacks) {
  const root = createRoot(element);
  root.render(<MovieTable initialPage={initialPage} onPageChange={callbacks.onPageChange} />);
  return {
    update(nextPage) {
      root.render(<MovieTable initialPage={nextPage} onPageChange={callbacks.onPageChange} />);
    },
    unmount() {
      root.unmount();
    }
  };
}
