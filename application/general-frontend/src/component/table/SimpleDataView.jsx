import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {Button} from 'primereact/button';
import { Card } from 'primereact/card';
import {DataView, DataViewLayoutOptions} from 'primereact/dataview';

class SimpleDataView extends Component {
    constructor(props) {
        super(props);
    }

    isSelected(item) {
        if (this.props.selectedItem === item) {
            return true;
        }
        else {
            return false;
        }
    }

    itemTemplate(item) {
        return (
            <div className={"p-col-12 item" + (this.isSelected(item) ? ' item-selected' : '')} onClick={this.props.onDataItemSelect.bind(null, item)}>
                <b>{item.name}</b>
            </div>
        );
    }

    render() {
        return (
            <Card title={this.props.title} className="wc">
                <div className="p-col-12">
                    <DataView value={this.props.dataItems} layout="list" itemTemplate={this.itemTemplate.bind(this)}></DataView>
                </div>
                <div className="wc-button-container p-col-12">
                    <Button label="New" className="p-button-raised" icon="pi pi-plus" onClick={this.props.onDataItemNew} />
                </div>
            </Card>
        );
    }
}

SimpleDataView.propTypes = {
    dataItems: PropTypes.array.isRequired,
    title: PropTypes.string,
    selectedItem: PropTypes.object,
    onDataItemSelect: PropTypes.func,
    onDataItemNew: PropTypes.func
}

SimpleDataView.defaultProps = {
    dataItems: ['No Items'],
    title: '###'
}

export default SimpleDataView;