class ApiService {
    public getAction(): string {
        // Business logic for GET action
        return "GET action executed by armando  ";
    }

    public postAction(data: any): string {
        // Business logic for POST action
        return `POST action executed with data: ${JSON.stringify(data)}`;
    }
}

export default ApiService;