import React, { Component } from 'react';
import BranchDetail from '../component/branch/BranchDetail'
import SimpleDataView from '../component/table/SimpleDataView'
import {BranchService} from '../service/BranchService'

class Branches extends Component {
    constructor(props) {
        super(props);
        this.state = {
            branches: [],
            branch: {}
        }
        this.service = new BranchService();
    }

    componentWillMount() {
        this.loadData();
    }

    loadData() {
        this.service.list().then(branches => {
            this.setState({ 
                branches: branches,
                branch: branches[0]
            });
        });
    }

    onDataItemNewEvent() {
        this.service.make().then(branch => {
            this.setState({ 
                branch: branch,
            });
        });
    }

    onDataItemSaveEvent(item) {
        this.service.save(item).then(branch => {
            this.service.list().then(branches => {
                this.setState({ 
                    branches: branches,
                    branch: branch
                });
            });
        });
    }

    onDataItemSelectEvent(item) {
        this.setState({ branch: item });
    }

    onDataItemRemoveEvent(item) {
        this.service.delete(item.id).then(() => {
            this.loadData();
        });
    }

    render() {
        return (
            <div className="p-grid">
                <div className="p-col-12 p-md-6 p-lg-3">
                    <SimpleDataView 
                        dataItems={this.state.branches}
                        title="Branches"
                        selectedItem={this.state.branch}
                        onDataItemSelect={this.onDataItemSelectEvent.bind(this)}
                        onDataItemNew={this.onDataItemNewEvent.bind(this)}
                    />
                </div>
                {!(Object.keys(this.state.branches).length === 0 && this.state.branches.constructor === Object) && 
                    <div className="p-col-12 p-md-6 p-lg-9">
                        <BranchDetail 
                            branch={this.state.branch}
                            onDataItemSave={this.onDataItemSaveEvent.bind(this)}
                            onDataItemRemove={this.onDataItemRemoveEvent.bind(this)}
                        />
                    </div>
                }
            </div>
        );
    }
}

export default Branches;