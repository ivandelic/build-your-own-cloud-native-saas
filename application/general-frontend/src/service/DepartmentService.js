export class DepartmentService {

    constructor() {
        this.baseUrl = process.env.REACT_APP_DEPARTMENT_API_URL;
    }

    make() {
        console.log("aaa")
        return new Promise((resolve, reject) => {
            resolve({
                "id": "",
                "name": "",
                "code": "",
                "description": "test"
            });
        });
    }

    list() {
        return fetch(this.baseUrl + "/departments").then(promise => promise.json());
    }

    get(id) {
        return fetch(this.baseUrl + "/departments/" + id).then(promise => promise.json());
    }

    save(item) {
        if (!item.id) {
            return this.create(item);
        }
        else {
            return this.update(item);
        }
    }

    update(item) {
        return fetch(this.baseUrl + "/departments/", {
            method: 'POST',
            body: JSON.stringify(item),
            headers: {
                'Content-Type': 'application/json'
            }
        }).then(promise => promise.json());
    }

    create(item) {
        return fetch(this.baseUrl + "/departments/", {
            method: 'PUT',
            body: JSON.stringify(item),
            headers: {
                'Content-Type': 'application/json'
            }
        }).then(promise => promise.json());
    }

    delete(id) {
        return fetch(this.baseUrl + "/departments/" + id, { method: 'DELETE' });
    }
}