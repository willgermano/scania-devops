import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Component, OnInit, inject, signal } from '@angular/core';

interface WeatherForecast {
  date: string;
  temperatureC: number;
  temperatureF: number;
  summary: string;
}

@Component({
  selector: 'app-root',
  imports: [],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly endpoint = '/api/weatherforecast';

  protected readonly sourceEndpoint = 'http://localhost:8082/weatherforecast';
  protected readonly forecasts = signal<WeatherForecast[]>([]);
  protected readonly loading = signal(false);
  protected readonly error = signal<string | null>(null);

  ngOnInit(): void {
    this.load();
  }

  protected load(): void {
    this.loading.set(true);
    this.error.set(null);

    this.http.get<WeatherForecast[]>(this.endpoint).subscribe({
      next: (data) => {
        this.forecasts.set(data);
        this.loading.set(false);
      },
      error: (error: HttpErrorResponse) => {
        const detail = error.status ? `Status ${error.status}` : 'sem resposta';
        this.error.set(
          `Nao foi possivel carregar o endpoint (${detail}). Confira se a API Docker esta em ${this.sourceEndpoint}.`,
        );
        this.loading.set(false);
      },
    });
  }
}
