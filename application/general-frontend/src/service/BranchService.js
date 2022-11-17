export class BranchService {

    constructor() {
        this.baseUrl = process.env.REACT_APP_BRANCH_API_URL;
    }

    make() {
        console.log("aaa")
        return new Promise((resolve, reject) => {
            resolve({
                "id": "",
                "name": "",
                "city": "",
                "address": "",
                "description": ""
            });
        });
    }

    list() {
        return fetch(this.baseUrl + "/branches").then(promise => promise.json());
    }

    get(id) {
        return fetch(this.baseUrl + "/branches/" + id).then(promise => promise.json());
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
        return fetch(this.baseUrl + "/branches/", {
            method: 'POST',
            body: JSON.stringify(item),
            headers: {
                'Content-Type': 'application/json'
            }
        }).then(promise => promise.json());
    }

    create(item) {
        return fetch(this.baseUrl + "/branches/", {
            method: 'PUT',
            body: JSON.stringify(item),
            headers: {
                'Content-Type': 'application/json'
            }
        }).then(promise => promise.json());
    }

    delete(id) {
        return fetch(this.baseUrl + "/branches/" + id, { method: 'DELETE' });
    }
}